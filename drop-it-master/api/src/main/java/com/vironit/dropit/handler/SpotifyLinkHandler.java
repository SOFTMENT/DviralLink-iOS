package com.vironit.dropit.handler;

import static java.util.Optional.ofNullable;

import java.util.Arrays;
import java.util.Set;

import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.vironit.dropit.model.Post;
import com.wrapper.spotify.SpotifyApi;
import com.wrapper.spotify.model_objects.credentials.ClientCredentials;
import com.wrapper.spotify.model_objects.specification.Album;
import com.wrapper.spotify.model_objects.specification.Artist;
import com.wrapper.spotify.model_objects.specification.ArtistSimplified;
import com.wrapper.spotify.model_objects.specification.Image;
import com.wrapper.spotify.model_objects.specification.Playlist;
import com.wrapper.spotify.model_objects.specification.Track;

@Component
@Slf4j
public class SpotifyLinkHandler {

	private final Set<String> LINK_TYPES = Set.of("album", "track", "playlist", "artist");

	@Value("${spotify.clientId}")
	private String clientId;

	@Value("${spotify.clientSecret}")
	private String clientSecret;

	public Post handleLink(String link) {
		String type = LINK_TYPES.stream()
				.filter(e -> link.contains(e))
				.findFirst()
				.orElseThrow();
		switch (type) {
			case "album":
				return processAlbum(link);
			case "track":
				return processTrack(link);
			case "playlist":
				return processPlaylist(link);
			case "artist":
				return processArtist(link);
			default:
				throw new RuntimeException();
		}
	}

	@SneakyThrows
	private Post processAlbum(String link) {
		String id = link.substring(31);
		id = getIdFromUriVariable(id);
		Album album = getSpotifyApi().getAlbum(id).build().execute();
		return new Post()
				.setLink(link)
				.setSongName(formatArtistsName(album.getArtists()) + " - " + album.getName())
				.setPicture(getImageUrl(album.getImages()[0]));
	}

	@SneakyThrows
	private Post processArtist(String link) {
		String id = link.substring(32);
		id = getIdFromUriVariable(id);
		Artist artist = getSpotifyApi().getArtist(id).build().execute();
		return new Post()
				.setLink(link)
				.setSongName(artist.getName())
				.setPicture(getImageUrl(artist.getImages()[0]));
	}

	@SneakyThrows
	private Post processPlaylist(String link) {
		String id = link.substring(34);
		id = getIdFromUriVariable(id);
		Playlist playlist = getSpotifyApi().getPlaylist(id).build().execute();
		return new Post()
				.setLink(link)
				.setSongName(playlist.getName())
				.setPicture(getImageUrl(playlist.getImages()[0]));
	}

	@SneakyThrows
	private Post processTrack(String link) {
		String id = link.substring(31);
		id = getIdFromUriVariable(id);
		Track track = getSpotifyApi().getTrack(id).build().execute();
		return new Post()
				.setLink(link)
				.setSongName(formatArtistsName(track.getArtists()) + " - " + track.getName())
				.setPicture(getImageUrl(track.getAlbum().getImages()[0]));
	}

	private String getImageUrl(Image image) {
		return ofNullable(image)
				.orElseThrow()
				.getUrl();
	}

	private String getIdFromUriVariable(String uriVariable) {
		if (uriVariable.contains("?")) {
			uriVariable = uriVariable.split("\\?")[0];
		}
		return uriVariable;
	}

	private String formatArtistsName(ArtistSimplified[] artists) {
		if (artists.length > 1) {
			return Arrays.stream(artists)
					.map(ArtistSimplified::getName)
					.reduce((s, s2) -> s + ", " + s2)
					.orElseThrow();
		} else {
			return artists[0].getName();
		}
	}

	@SneakyThrows
	private SpotifyApi getSpotifyApi() {
		SpotifyApi spotifyApi = SpotifyApi.builder()
				.setClientId(clientId)
				.setClientSecret(clientSecret)
				.build();
		ClientCredentials clientCredentials = spotifyApi.clientCredentials().build().execute();
		spotifyApi.setAccessToken(clientCredentials.getAccessToken());
		return spotifyApi;
	}
}