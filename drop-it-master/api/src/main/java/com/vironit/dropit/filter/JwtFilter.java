package com.vironit.dropit.filter;

import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.security.UserAuthentication;
import com.vironit.dropit.service.impl.UserServiceImpl;
import com.vironit.dropit.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtFilter extends OncePerRequestFilter {

    private final UserServiceImpl userService;
    private final JwtUtil jwtUtil;

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER = "Bearer ";
    private static final String ROLE_PREFIX = "ROLE_";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        final String requestTokenHeader = request.getHeader(AUTHORIZATION_HEADER);

        String email = null;
        String jwtToken = null;

        if (requestTokenHeader != null && requestTokenHeader.startsWith(BEARER)) {
            jwtToken = requestTokenHeader.substring(7);
            email = jwtUtil.getClaimFromToken(jwtToken, "sub");
        } else {
            log.warn("JWT Token does not begin with Bearer String");
        }
        if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDto userDto = userService.findByEmail(email);
            if (jwtUtil.validateToken(jwtToken, userDto)) {
                UserAuthentication userAuthentication = new UserAuthentication(true, userDto,
                        Collections.singletonList(new SimpleGrantedAuthority(ROLE_PREFIX + userDto.getRole().getName())));
                SecurityContextHolder.getContext().setAuthentication(userAuthentication);
            }
        }
        chain.doFilter(request, response);
    }
}