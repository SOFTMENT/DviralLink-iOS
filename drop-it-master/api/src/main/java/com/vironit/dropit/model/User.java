package com.vironit.dropit.model;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Data
@Accessors(chain = true)
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column
    private String email;

    @Column
    private String password;

    @Column
    private String name;

    @Column(name = "about_user")
    private String aboutUser;

    @Column(name = "instagram_account")
    private String instagramAccount;

    @Column(name = "twitter_account")
    private String twitterAccount;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(name = "authentication_provider")
    private AuthenticationProvider authenticationProvider;

    @Column
    private boolean confirmed;

    @Column(name = "posts_views")
    private int postsViews;

    public boolean isAdmin() {
        return role.getName().equals("ADMIN");
    }
}