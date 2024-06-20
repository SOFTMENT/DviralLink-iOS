package com.vironit.dropit.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import com.vironit.dropit.service.NotificationService;
import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.vironit.dropit.dto.PostDto;
import com.vironit.dropit.dto.PostGroupWrapper;
import com.vironit.dropit.dto.PostInputDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.dto.converter.PostConverter;
import com.vironit.dropit.exception.BadRequestException;
import com.vironit.dropit.exception.NotFoundEntityException;
import com.vironit.dropit.model.Post;
import com.vironit.dropit.model.User;
import com.vironit.dropit.repository.PostRepository;
import com.vironit.dropit.repository.UserRepository;
import com.vironit.dropit.service.LinkService;
import com.vironit.dropit.service.PostService;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

	private static final int VIEWS_TO_POST = 5;

	private final PostRepository postRepository;
	private final UserRepository userRepository;
	private final PostConverter converter;
	private final LinkService linkService;
	private final NotificationService notificationService;

	public PostDto findById(long id) {
		return converter.toDto(postRepository.findById(id).orElseThrow(() -> new NotFoundEntityException("No post with id = " + id)));
	}

	public List<PostGroupWrapper> findAll() {
		List<PostDto> posts = postRepository.findAll().stream().map(converter::toDto).collect(Collectors.toList());
		Set<LocalDate> dates = posts.stream().map(post -> post.getCreationTime().toLocalDate()).collect(Collectors.toSet());
		return dates.stream()
				.map(date -> new PostGroupWrapper(date, posts.stream().filter(post -> post.getCreationTime().toLocalDate().equals(date)).collect(Collectors.toList())))
				.sorted(Comparator.comparing(PostGroupWrapper::getDate).reversed())
				.collect(Collectors.toList());
	}

	@Transactional(isolation = Isolation.REPEATABLE_READ)
	public PostDto create(PostInputDto dto) {
		User user = userRepository.findById(dto.getAuthorId()).orElseThrow(() -> new BadRequestException("No user with id = " + dto.getAuthorId()));
		if (user.getPostsViews() >= VIEWS_TO_POST || user.isAdmin()) {
			Post post = linkService.formPost(dto.getLink())
					.setAuthor(user)
					.setCreationTime(LocalDateTime.now());
			if (!user.isAdmin()) {
				userRepository.saveAndFlush(user.setPostsViews(0));
			}
			String username = user.getName();
			if (username == null) {
				username = user.getEmail();
			}
			notificationService.senNotificationToAllUsers(username, user);
			return converter.toDto(postRepository.save(post));
		} else {
			throw new AccessDeniedException("You have viewed only " + user.getPostsViews() + " posts.");
		}
	}

	@Transactional
	public void delete(long id, UserDto principal) {
		Post post = postRepository.findById(id).orElseThrow(() -> new BadRequestException("No post with id = " + id));
		if (post.getAuthor().getId() == principal.getId() || principal.isAdmin()) {
			postRepository.deleteById(id);
		} else {
			throw new AccessDeniedException("You can't delete other user's posts.");
		}
	}

	@Transactional
	public void deleteOldPosts() {
		postRepository.deleteByCreationTimeBefore(LocalDateTime.now().minusDays(7));
	}
}