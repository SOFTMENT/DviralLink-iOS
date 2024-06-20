package com.vironit.dropit.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

import java.util.List;

import javax.validation.Valid;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.vironit.dropit.dto.PostDto;
import com.vironit.dropit.dto.PostGroupWrapper;
import com.vironit.dropit.dto.PostInputDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.service.PostService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/posts")
public class PostController {

    private final PostService service;

    @GetMapping
    @Operation(summary = "Get all posts.")
    @ApiResponse(responseCode = "200", description = "Returned list of all posts",
            content = {@Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = PostGroupWrapper.class)))})
    public List<PostGroupWrapper> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a single post by id.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Found a post.",
                    content = {@Content(mediaType = "application/json", schema = @Schema(implementation = PostDto.class))}),
            @ApiResponse(responseCode = "404", description = "Post not found", content = @Content())
    })
    public PostDto findById(@Parameter(description = "id of a post to get") @PathVariable long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a post")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Post successfully created",
                    content = {@Content(mediaType = "application/json", schema = @Schema(implementation = PostDto.class))}),
            @ApiResponse(responseCode = "403", description = "User watched less then 20 posts.", content = @Content())
    })
    public PostDto create(@RequestBody @Valid PostInputDto post) {
        UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return service.create(post.setAuthorId(principal.getId()));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a post by id")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Post deleted successfully."),
            @ApiResponse(responseCode = "403", description = "User trying to delete other user's post."),
            @ApiResponse(responseCode = "404", description = "No post with given id.")
    })
    public void delete(@Parameter(description = "id of a post to delete") @PathVariable long id) {
        UserDto principal = (UserDto) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        service.delete(id, principal);
    }
}