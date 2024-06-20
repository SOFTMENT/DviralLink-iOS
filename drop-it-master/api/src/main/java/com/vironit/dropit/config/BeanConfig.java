package com.vironit.dropit.config;

import io.fusionauth.jwt.Verifier;
import io.fusionauth.jwt.hmac.HMACVerifier;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.json.JacksonJsonParser;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.youtube.YouTube;

@Configuration
public class BeanConfig {

    @Value("${jwt.secret}")
    private String secret;

    @Bean
    public ModelMapper modelMapper() {
        return new ModelMapper();
    }

    @Bean
    public Verifier verifier() {
        return HMACVerifier.newVerifier(secret);
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Bean
    public JacksonJsonParser jacksonJsonParser() {
        return new JacksonJsonParser();
    }

    @Bean
    public YouTube youTube() {
        return new YouTube.Builder(new NetHttpTransport(), new GsonFactory(), httpRequest -> {}).setApplicationName("drop-it-test-app").build();
    }

//    @Bean
//    @Scope("periodical")
//    @SneakyThrows
//    public SpotifyApi getSpotifyApi() {
//        SpotifyApi spotifyApi = SpotifyApi.builder()
//                .setClientId(clientId)
//                .setClientSecret(clientSecret)
//                .build();
//        ClientCredentials clientCredentials = spotifyApi.clientCredentials().build().execute();
//        spotifyApi.setAccessToken(clientCredentials.getAccessToken());
//        return spotifyApi;
//    }
}