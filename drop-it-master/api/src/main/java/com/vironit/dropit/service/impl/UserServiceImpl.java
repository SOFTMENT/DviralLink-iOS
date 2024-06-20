package com.vironit.dropit.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import lombok.RequiredArgsConstructor;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.vironit.dropit.dto.SignUpForm;
import com.vironit.dropit.dto.UpdatePasswordDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.dto.UserUpdateDto;
import com.vironit.dropit.dto.converter.UserConverter;
import com.vironit.dropit.exception.BadRequestException;
import com.vironit.dropit.exception.NotFoundEntityException;
import com.vironit.dropit.exception.TokenExpiredException;
import com.vironit.dropit.model.AuthenticationProvider;
import com.vironit.dropit.model.Role;
import com.vironit.dropit.model.Token;
import com.vironit.dropit.model.TokenPurpose;
import com.vironit.dropit.model.User;
import com.vironit.dropit.repository.TokenRepository;
import com.vironit.dropit.repository.UserRepository;
import com.vironit.dropit.service.UserService;
import com.vironit.dropit.util.EmailSender;
import com.vironit.dropit.util.LinkGenerator;
import com.vironit.dropit.util.ShaPasswordEncoder;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

	private final UserRepository userRepository;
	private final TokenRepository tokenRepository;
	private final ShaPasswordEncoder passwordEncoder;
	private final EmailSender emailSender;
	private final UserConverter converter;
	private final LinkGenerator linkGenerator;

	private static final String BAD_CREDENTIALS_MESSAGE = "Email or password is incorrect. Please try again.";
	private static final String NO_ACCOUNT = "We don't have an account for that email. Try to register instead.";
	private static final String REGISTRATION_EXPIRED = "The registration link is expired or doesn't exist.";
	private static final String RETRIEVE_PASSWORD_EXPIRED = "The retrieve password link is expired. Please repeat the password change process one more time.";
	private static final String NOT_CONFIRMED = "Registration process is not completed, check your email.";

	private static final int VIEWS_TO_POST = 5;

	public UserDto findById(long id) {
		return converter.toDto(userRepository.findById(id).orElseThrow(() -> new NotFoundEntityException("No user with id = " + id)));
	}

	public UserDto findByEmail(String email) {
		return converter.toDto(userRepository.findByEmailAndConfirmed(email, true).orElseThrow(() -> new NotFoundEntityException("No user with email = " + email)));
	}

	public UserDto authenticate(String email, String password) {
		User user = userRepository.findByEmailAndPassword(email, passwordEncoder.encode(password))
				.orElseThrow(() -> new BadCredentialsException(BAD_CREDENTIALS_MESSAGE));
		if (user.isConfirmed()) {
			return converter.toDto(user);
		} else {
			throw new DisabledException(NOT_CONFIRMED);
		}
	}

	@Transactional(isolation = Isolation.REPEATABLE_READ)
	public UserDto update(UserUpdateDto dto, long id) {
		User user = userRepository.findById(id).orElseThrow(() -> new NotFoundEntityException("No user with id = " + id));
		user.setName(dto.getName())
				.setAboutUser(dto.getAboutUser())
				.setInstagramAccount(dto.getInstagramAccount())
				.setTwitterAccount(dto.getTwitterAccount());
		return converter.toDto(userRepository.saveAndFlush(user));
	}

	@Transactional(isolation = Isolation.REPEATABLE_READ)
	public void signUp(SignUpForm signUpForm) {
		User user = userRepository.save(new User()
				.setEmail(signUpForm.getEmail())
				.setPassword(passwordEncoder.encode(signUpForm.getPassword()))
				.setRole(new Role(1, "USER"))
				.setConfirmed(false)
				.setAuthenticationProvider(AuthenticationProvider.LOCAL));
		Token token = tokenRepository.save(generateToken(user).setPurpose(TokenPurpose.REGISTRATION));
		emailSender.sendRegistrationMail(user.getEmail(), linkGenerator.generateSignUpLink(token.getKey()));
	}

	@Transactional(isolation = Isolation.REPEATABLE_READ)
	public void confirmRegistration(String key) {
		Optional<Token> registrationKey = tokenRepository.findById(key);
		if (registrationKey.isPresent()) {
			tokenRepository.deleteById(key);
			userRepository.saveAndFlush(registrationKey.get().getUser().setConfirmed(true));
		} else {
			throw new TokenExpiredException(REGISTRATION_EXPIRED);
		}
	}

	public UserDto findOrSaveSocialNetworkUser(String email, AuthenticationProvider authenticationProvider) {
		return converter.toDto(userRepository.findByEmailAndConfirmed(email, true).orElseGet(() -> userRepository.save(new User()
				.setEmail(email)
				.setConfirmed(true)
				.setRole(new Role(1, "USER"))
				.setAuthenticationProvider(authenticationProvider))));
	}

	@Transactional
	public void deleteExpiredKeys() {
		List<Token> expiredKeys = tokenRepository.findExpiredTokens();
		expiredKeys.forEach(token -> deleteExpiredToken(token));
	}

	@Transactional
	public void sendResetPasswordMessage(String email) {
		User user = userRepository.findByEmailAndConfirmed(email, true)
				.orElseThrow(() -> new NotFoundEntityException(NO_ACCOUNT));
		Token token = tokenRepository.save(generateToken(user).setPurpose(TokenPurpose.PASSWORD_RETRIEVING));
		emailSender.sendPasswordResetMessage(user.getEmail(), linkGenerator.generateResetPasswordLink(token.getKey()));
	}

	@Transactional
	public void resetPassword(String key) {
		Token token = tokenRepository.findById(key).orElseThrow(() -> new TokenExpiredException(RETRIEVE_PASSWORD_EXPIRED));
		userRepository.saveAndFlush(token.getUser().setPassword(null));
		tokenRepository.delete(token);
	}

	@Transactional
	public void updatePassword(UpdatePasswordDto dto) {
		User user = userRepository.findByEmailAndConfirmed(dto.getEmail(), true).orElseThrow(() -> new BadRequestException("No user with email = " + dto.getEmail()));
		if (user.getPassword() == null) {
			user.setPassword(passwordEncoder.encode(dto.getPassword()));
			userRepository.saveAndFlush(user);
		} else {
			throw new BadRequestException("Check your email to reset the password first.");
		}
	}

	@Transactional
	public void incrementViews(long id) {
		User user = userRepository.findById(id).orElseThrow(() -> new BadRequestException("No user with id = " + id));
		if (!user.isAdmin() || user.getPostsViews() != VIEWS_TO_POST) {
			user.setPostsViews(user.getPostsViews() + 1);
			userRepository.saveAndFlush(user);
		}
	}

	@Override
	public int getViewsById(long id) {
		User user = userRepository.findById(id).orElseThrow(() -> new BadRequestException("No user with id = " + id));
		return user.getPostsViews();
	}

	private Token generateToken(User user) {
		return new Token()
				.setUser(user)
				.setKey(passwordEncoder.encode(user.getId() + user.getEmail()))
				.setExpirationTime(LocalDateTime.now().plusHours(24));
	}

	private void deleteExpiredToken(Token token) {
		switch (token.getPurpose()) {
			case REGISTRATION:
				tokenRepository.delete(token);
				userRepository.delete(token.getUser());
				break;
			case PASSWORD_RETRIEVING:
				tokenRepository.delete(token);
				break;
		}
	}
}