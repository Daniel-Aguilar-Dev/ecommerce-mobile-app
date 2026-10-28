package utez.edu.mx.ecommerceapi.shared.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import utez.edu.mx.ecommerceapi.auth.security.JwtAuthenticationFilter;
import utez.edu.mx.ecommerceapi.auth.security.JwtService;
import utez.edu.mx.ecommerceapi.auth.service.RefreshTokenService;
import utez.edu.mx.ecommerceapi.shared.exception.ApiSecurityErrorHandler;

@Configuration
public class SecurityConfig {

        @Bean
        public SecurityFilterChain filterChain(
                        HttpSecurity http,
                        JwtService jwtService,
                        RefreshTokenService refreshTokenService,
                        ApiSecurityErrorHandler errorHandler) throws Exception {
                JwtAuthenticationFilter jwtFilter = new JwtAuthenticationFilter(
                                jwtService,
                                refreshTokenService,
                                errorHandler);

                http
                                .csrf(AbstractHttpConfigurer::disable)
                                .formLogin(AbstractHttpConfigurer::disable)
                                .httpBasic(AbstractHttpConfigurer::disable)
                                .logout(AbstractHttpConfigurer::disable)
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                                .exceptionHandling(exceptions -> exceptions
                                                .authenticationEntryPoint(errorHandler)
                                                .accessDeniedHandler(errorHandler))
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                                                .requestMatchers(
                                                                "/swagger-ui.html",
                                                                "/swagger-ui/**",
                                                                "/v3/api-docs",
                                                                "/v3/api-docs/**",
                                                                "/api/v1/auth/login",
                                                                "/api/v1/auth/registro",
                                                                "/api/v1/auth/refresh",
                                                                "/api/v1/auth/logout",
                                                                "/api/v1/categorias/public/**",
                                                                "/api/v1/productos/public/**")
                                                .permitAll()
                                                .requestMatchers("/api/v1/usuarios/**")
                                                .hasRole("ADMINISTRADOR")
                                                .requestMatchers(
                                                                HttpMethod.GET,
                                                                "/api/v1/categorias",
                                                                "/api/v1/categorias/*")
                                                .hasAnyRole("EMPLEADO", "ADMINISTRADOR")
                                                .requestMatchers(HttpMethod.POST, "/api/v1/categorias")
                                                .hasAnyRole("EMPLEADO", "ADMINISTRADOR")
                                                .requestMatchers(
                                                                HttpMethod.PATCH,
                                                                "/api/v1/categorias/*")
                                                .hasRole("ADMINISTRADOR")
                                                .requestMatchers(
                                                                HttpMethod.DELETE,
                                                                "/api/v1/categorias/*")
                                                .hasRole("ADMINISTRADOR")
                                                .requestMatchers("/api/v1/productos/**")
                                                .hasAnyRole("EMPLEADO", "ADMINISTRADOR")
                                                .requestMatchers("/api/v1/ping")
                                                .hasAnyRole("CLIENTE", "EMPLEADO", "ADMINISTRADOR")
                                                .anyRequest().denyAll())
                                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }
}
