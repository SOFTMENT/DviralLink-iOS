package com.vironit.dropit.handler;

import static com.vironit.dropit.util.LinkSources.YOUTUBE_LINK;
import static com.vironit.dropit.util.LinkSources.YOUTUBE_SHARE_LINK;

import java.util.Optional;

import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.google.api.services.youtube.YouTube;
import com.google.api.services.youtube.model.Video;
import com.google.api.services.youtube.model.VideoListResponse;
import com.vironit.dropit.constraint.LinkProperties;
import com.vironit.dropit.exception.BadRequestException;
import com.vironit.dropit.model.Post;

@Component
@RequiredArgsConstructor
@Slf4j
public class YoutubeLinkHandler {

	private final LinkProperties linkProperties;
	private final YouTube youTube;

	@Value("${api.key}")
	private String apiKey;

	public Post handleLink(String link) {
		String source = linkProperties.getSources().stream().filter(s -> link.startsWith(s)).findFirst().get();
		String id = null;
		switch (source) {
			case YOUTUBE_LINK:
				id = link.substring(source.length() + 9);
				break;
			case YOUTUBE_SHARE_LINK:
				id = link.substring(source.length() + 1);
				break;
		}
		Video video = getVideo(id);
		return new Post()
				.setLink(link)
				.setPicture(video.getSnippet().getThumbnails().getMaxres().getUrl())
				.setSongName(video.getSnippet().getTitle());
	}

	@SneakyThrows
	private Video getVideo(String id) {
		YouTube.Videos.List videoRequest = youTube.videos().list("snippet");
		videoRequest.setId(id);
		videoRequest.setKey(apiKey);
		VideoListResponse listResponse = videoRequest.execute();
		return Optional.of(listResponse.getItems())
				.map(videos -> videos.get(0))
				.orElseThrow(() -> new BadRequestException("Video not found."));
	}
}