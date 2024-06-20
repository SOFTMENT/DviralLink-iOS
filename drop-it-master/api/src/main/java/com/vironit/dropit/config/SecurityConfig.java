package com.vironit.dropit.config;

import com.vironit.dropit.filter.JwtFilter;
import com.vironit.dropit.security.JwtAuthenticationEntryPoint;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@RequiredArgsConstructor
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final JwtAuthenticationEntryPoint entryPoint;
    private final JwtFilter filter;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers(HttpMethod.GET, "/swagger**").permitAll()
                .antMatchers(HttpMethod.GET, "/swagger-ui/**").permitAll()
                .antMatchers(HttpMethod.GET, "/api-docs**").permitAll()
                .antMatchers(HttpMethod.GET, "/api-docs/**").permitAll()
                .antMatchers(HttpMethod.POST, "/sign-in").permitAll()
                .antMatchers(HttpMethod.POST, "/sign-up").permitAll()
                .antMatchers(HttpMethod.GET, "/sign-up/**").permitAll()
                .antMatchers(HttpMethod.GET, "/reset-password**").permitAll()
                .antMatchers(HttpMethod.GET, "/confirm-reset-password/**").permitAll()
                .antMatchers(HttpMethod.PATCH, "/set-password").permitAll()
                .antMatchers(HttpMethod.POST, "/social-login").permitAll()
                .anyRequest().authenticated()
                .and()
                .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .csrf()
                .disable()
                .exceptionHandling().authenticationEntryPoint(entryPoint)
                .and()
                .addFilterBefore(filter, UsernamePasswordAuthenticationFilter.class);
    }
}