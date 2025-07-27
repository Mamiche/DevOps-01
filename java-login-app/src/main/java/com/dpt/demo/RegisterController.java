package com.dpt.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class RegisterController {

    private final JdbcTemplate jdbcTemplate;

    @Value("${spring.datasource.url}")
    private String url;

    @Value("${spring.datasource.username}")
    private String dbUsername;

    @Value("${spring.datasource.password}")
    private String dbPassword;

    public RegisterController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/register")
    public ModelAndView showRegisterForm() {
        return new ModelAndView("register");
    }

    @PostMapping("/register")
    public ModelAndView register(String firstName, String lastName, String email, String userName, String password) {
        String sql = "INSERT INTO Employee (first_name, last_name, email, username, password, regdate) VALUES (?, ?, ?, ?, ?, CURDATE())";
        jdbcTemplate.update(sql, firstName, lastName, email, userName, password);

        ModelAndView mv = new ModelAndView("register");
        mv.addObject("message", "User account created for " + userName);
        return mv;
    }
}

