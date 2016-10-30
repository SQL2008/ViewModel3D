package com.model.view.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.ui.Model;

@Controller
public class ParamController {
    @RequestMapping(value = "/param")
    public String greetingForm(Model model) {
        //model.addAttribute("greeting", new Greeting());
        return "param";
    }
}
