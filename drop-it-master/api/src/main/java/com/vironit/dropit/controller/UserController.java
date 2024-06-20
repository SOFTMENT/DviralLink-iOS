package com.vironit.dropit.controller;

import com.vironit.dropit.dto.DeviceTokenDto;
import com.vironit.dropit.service.DeviceTokenService;
import com.vironit.dropit.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

import javax.validation.Valid;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.dto.UserUpdateDto;
import com.vironit.dropit.service.impl.UserServiceImpl;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
public class UserController {

	private final UserServiceImpl userService;
	private final DeviceTokenService deviceTokenService;

	@GetMapping("/{id}")
	@Operation(summary = "Get a user by id.")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "User found.",
					content = { @Content(mediaType = "application/json", schema = @Schema(implementation = UserDto.class)) }),
			@ApiResponse(responseCode = "404", description = "User not found.", content = @Content())
	})
	public UserDto getUserById(@Parameter(description = "id of user to find") @PathVariable long id) {
		return userService.findById(id);
	}

	@GetMapping("/{id}/views")
	@Operation(summary = "Get views of a user by given id.")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "Returned views of a user.",
					content = { @Content(mediaType = "application/json") }),
			@ApiResponse(responseCode = "400", description = "User not found by given id.",
					content = { @Content(mediaType = "application/json") })
	})
	public int getViewsOfUserById(@PathVariable long id) {
		return userService.getViewsById(id);
	}

	@PutMapping("/{id}")
	@Operation(summary = "Update user's profile information.")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "Successfully updated user's information", content = {
					@Content(mediaType = "application/json", schema = @Schema(implementation = UserDto.class)) }),
			@ApiResponse(responseCode = "403", description = "User is trying to update other user's information.", content = @Content()),
			@ApiResponse(responseCode = "404", description = "No user with given id.", content = @Content()),
			@ApiResponse(responseCode = "401", description = "Invalid profile data.", content = @Content())
	})
	public UserDto updateUser(@Valid @RequestBody UserUpdateDto dto, @Parameter(description = "Id of updatable user.") @PathVariable long id) {
		UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		if (principal.getEmail().equals(userService.findById(id).getEmail()) || principal.isAdmin()) {
			return userService.update(dto, id);
		} else {
			throw new AccessDeniedException("You can't update other user's profile.");
		}
	}

	@PatchMapping("/views")
	@Operation(summary = "Increment user's views number")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "Successfully incremented views", content = @Content()),
			@ApiResponse(responseCode = "401", description = "User not found", content = @Content())
	})
	public void incrementViews() {
		UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		userService.incrementViews(principal.getId());
	}

	@PostMapping("/notifications")
	@Operation(summary = "Subscribe user on notifications")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "Successfully incremented views", content = @Content()),
			@ApiResponse(responseCode = "401", description = "User not found", content = @Content())
	})
	public void subscribeUserOnNotifications(@RequestBody DeviceTokenDto dto) {
		UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		deviceTokenService.subscribeUserOnNotifications(principal.getId(), dto.getToken());
	}
}