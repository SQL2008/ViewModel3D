package com.model.view.controller;

import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.ui.Model;

@Component
@Controller
public class ParamController {
    @RequestMapping(value = "/param")
    public String greetingForm(Model model) {
        model.addAttribute("message", "Test message!");
        return "param";
    }
}
