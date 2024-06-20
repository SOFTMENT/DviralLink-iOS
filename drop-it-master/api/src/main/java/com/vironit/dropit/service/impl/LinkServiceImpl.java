package com.vironit.dropit.service.impl;

import static com.vironit.dropit.util.LinkSources.APPLE_MUSIC_LINK;
import static com.vironit.dropit.util.LinkSources.SPOTIFY_SHARE_LINK;
import static com.vironit.dropit.util.LinkSources.YOUTUBE_LINK;
import static com.vironit.dropit.util.LinkSources.YOUTUBE_SHARE_LINK;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;

import com.vironit.dropit.constraint.LinkProperties;
import com.vironit.dropit.exception.BadRequestException;
import com.vironit.dropit.handler.SpotifyLinkHandler;
import com.vironit.dropit.handler.YoutubeLinkHandler;
import com.vironit.dropit.model.Post;
import com.vironit.dropit.service.LinkService;

@RequiredArgsConstructor
@Service
public class LinkServiceImpl implements LinkService {

	private final LinkProperties linkProperties;

	private final YoutubeLinkHandler youtubeLinkHandler;
	private final SpotifyLinkHandler spotifyLinkHandler;

	private final String DEFAULT_PICTURE = "https://zerojackerzz.com/wp-content/uploads/2019/10/album-placeholder.png";

	@Override
	public Post formPost(String link) {
		String source = linkProperties.getSources().stream()
				.filter(s -> link.startsWith(s))
				.findFirst()
				.orElseThrow();
		Post post;
		switch (source) {
			case YOUTUBE_LINK:
			case YOUTUBE_SHARE_LINK:
				post = youtubeLinkHandler.handleLink(link);
				break;
			case APPLE_MUSIC_LINK:
				post = new Post()
						.setLink(link)
						.setSongName("Apple Music");
				break;
			case SPOTIFY_SHARE_LINK:
				post = spotifyLinkHandler.handleLink(link);
				break;
			default:
				throw new BadRequestException("Now you can only post youtube, spotify and Apple Music links");
		}
		if (post.getPicture() == null) {
			post.setPicture(DEFAULT_PICTURE);
		}
		return post;
	}
}
