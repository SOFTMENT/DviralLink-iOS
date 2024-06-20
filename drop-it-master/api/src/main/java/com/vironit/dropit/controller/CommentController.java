package com.vironit.dropit.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

import java.util.List;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.vironit.dropit.dto.CommentDto;
import com.vironit.dropit.dto.CommentInputDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.service.CommentService;

@RestController
@RequiredArgsConstructor
public class CommentController {

    private final CommentService service;

    @GetMapping("/posts/{postId}/comments")
    @Operation(summary = "Get a all comments of a post.")
    @ApiResponse(responseCode = "200", description = "Returned list of comments of a post.",
            content = {@Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = CommentDto.class)))})
    public List<CommentDto> findByPostId(@PathVariable @Parameter(description = "Id of post to find its comments") long postId) {
        return service.findByPostId(postId);
    }

    @PostMapping("/posts/{postId}/comments")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a comment to a post.")
    @ApiResponse(responseCode = "200", description = "Post created successfully.",
            content = {@Content(mediaType = "application/json", schema = @Schema(implementation = CommentDto.class))})
    public CommentDto create(@Parameter(description = "Id of a commented post.") @PathVariable long postId,
                             @RequestBody CommentInputDto dto) {
        return service.create(dto, postId);
    }

    @DeleteMapping("/comments/{id}")
    @Operation(summary = "Delete a comment of a post.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "403", description = "User trying to delete a comment of other user not being an author of this post.")
    })
    public void delete(@Parameter(description = "id of a comment to delete") @PathVariable long id) {
        UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        service.delete(id, principal);
    }
}