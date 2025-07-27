package com.dpt.demo;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.beans.factory.annotation.Autowired;

@Controller
public class LoginController {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public LoginController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/login")
    public ModelAndView showLoginForm() {
        return new ModelAndView("login");
    }

    @PostMapping("/login")
    public ModelAndView login(String userName, String password) {
        String sql = "SELECT username FROM Employee WHERE username = ? AND password = ?";
        ModelAndView mv;
        try {
            String userId = jdbcTemplate.queryForObject(sql, new Object[]{userName, password}, String.class);
            mv = new ModelAndView("user");
            mv.addObject("username", userId);
        } catch (Exception e) {
            mv = new ModelAndView("login");
            mv.addObject("errorMessage", "Invalid username or password");
        }
        return mv;
    }
}

