package com.stocksense.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class UserRequest {
    @NotBlank @Size(min = 3, max = 100)
    private String username;

    @NotBlank @Email
    private String email;

    @Size(min = 6)
    private String password;

    @NotBlank @Size(max = 200)
    private String fullName;

    private String phone;

    @NotNull
    private Long roleId;
}
