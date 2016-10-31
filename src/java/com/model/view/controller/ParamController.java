package com.model.view.controller;

//import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMethod;

//@Component
@Controller
@RequestMapping(value = "/param", method=RequestMethod.POST)
public class ParamController {
    
    public String greetingForm(Model model) {
        model.addAttribute("message", "Test message!");
        return "param";
    }
}
