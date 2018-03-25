---
layout: post
title: Integrating Auth0 with Vue and Vuex
---
While you can find very good documentation on Auth0 site for
[integrating Auth0 with Vue][1] it's based on managing state through
propagating props and custom events. The more practical and real-world
implementation would use [Vuex][2]. Therefore I've created an example
project integrating Auth0 with Vue and Vuex. It's based on a similar
concept as original documentation but uses Vuex for state management
and events handling.

### TL;DR

Further in this post I'm describing some of the aspects of the integration.
If're not interested though you can clone the [example code][3] from GitHub.

## Setup

In this post I assume you've already setup an Auth0 account and created the
Single Page Web Application client. If not refer to the [documentation][4] on
how to do it. I also assume you're familiar with OAuth2 authentication.

For this tutorial you'd need to have `npm` with `vue-cli` installed on
your machine with:

{% highlight bash %}
$ npm i -g @vue/cli
{% endhighlight %}

I assume you're familiar with [Vue CLI tool][5].

Generate new Vue project with:

{% highlight bash %}
$ vue create auth0-with-vue-and-vuex
{% endhighlight %}

Out of the features dialog you need to pick manual option and select `Router` and
`Vuex` to install necessary dependencies and configuration.

Finally install the *auth0.js* library.

{% highlight bash %}
$ npm i -S auth0-js
{% endhighlight %}

Now we're ready to go.

## Auth0 with Vue and Vuex

### Authentication service

The usage of *auth0.js* is pretty straightforward. Create an instance of
`auth0.WebAuth` providing your client configuration, request type and scope
than use `authorize` method to start login process and `parseHash` to parse
returned tokens. If you're familiar with OAuth2 you'd know that tokens will be
appended to the callback URL to which user is redirected to.

As the Auth0 documentation suggests best way is to encapsulate that logic with
reusable service. Let's create one:

{% highlight javascript %}
// src/lib/Authenticator.js

import auth0 from 'auth0-js'

export default class Authenticator {
  constructor () {
    this.auth0 = new auth0.WebAuth({
      domain: '{{ your_domain }}',
      clientID: '{{ your_client_id }}',
      redirectUri: 'http://localhost:8080/auth',
      audience: '{{ your_audience }}',
      responseType: 'token id_token',
      scope: 'openid'
    })
  }

  login () {
    this.auth0.authorize()
  }
}
{% endhighlight %}

You need to provide `domain`, `clientID`, `redirectUri` and `audience` to your
Auth0 client. Auth0 will generate that values for you which can be simply copy'n'pasted
to the actual code. The `login` method initiates the authentication flow by redirecting
user to the Auth0 login dialog.

### Creating user session store

We need a place to instantiate our `Authenticator` and where to keep user session information.
Since this post is about Vuex let's go ahead and firstly create a store for user session:

{% highlight javascript %}
// src/store/modules/session.js

import Authenticator from '@/lib/Authenticator'

const auth = new Authenticator()

const state = {}

const actions = {
  login () {
    auth.login()
  }
}

export default {
  state,
  actions
}
{% endhighlight %}

If you created new project with `vue-cli` you probably have `src/store.js` file. You can
use it as well but I prefer to rename that file to `src/store/index.js` and use modules
for concern separation. Both solutions works fine and it's the matter of preference which one
to use.

Our state is empty for now but we'd fill it up soon. Now we need to add this module to our
Vuex store:

{% highlight javascript %}
// src/store/index.js

import Vue from 'vue'
import Vuex from 'vuex'

import session from './modules/session'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    session
  }
})
{% endhighlight %}

Alright, now we're ready to fire the authentication flow.

## Triggering authentication

To initiate authentication we need to call `login` action from our store. Typically such
action is fired in response to clicking some button or link usually in page top nav bar.
Let's create a Vue component for that:

{% highlight html %}
// src/components/Navbar.vue

<template>
  <nav class="navbar navbar-dark bg-dark">
    <a href="#" class="navbar-brand">Auth0 with Vue and Vuex Example</a>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <button class="btn btn-primary" @click='login()'>Sign In</button>
      </li>
    </ul>
  </nav>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'Navbar',

  methods: mapActions(['login'])
}
</script>
{% endhighlight %}

When clicking our login button the `login` method is called which dispatches
the `login` action of our store. This will redirect user to Auth0 login dialog.

Please note using bootstrap. Simplest way of adding it is pasting the CDN link
in the `index.html` file. Alternatively `npm` package can be installed and imported
in `App` component.

We need to add our `Navbar` component the the `App` component:

{% highlight html %}
<template>
  <div id="app">
    <Navbar />
    <router-view/>
  </div>
</template>

<script>
import Navbar from '@/components/Navbar'

export default {
  components: { Navbar }
}
</script>
{% endhighlight %}

Now we can initiate login flow. Go ahead and run `npm run serve` navigate
to http://localhost:8080 and click the Sign In button. You should be redirected
to Auth0 login page.

## Handling Redirect

First part is done. We're initiating authentication flow and redirecting user
to login dialog managed by Auth0. Next step is to handle redirect callback.
Auth0 would append *auth_token* and *id_token* to the redirect URL we've
set in the initial request (http://localhost:8080/auth in our case). We should
validate those tokens to ensure they're generated by the trusted entity. Fortunatelly
the `WebAuth` object we've instantiated in `Authenticator` has a build in method for that.
So let's start with extending our authentication service:

{% highlight javascript %}
export default class Authenticator {
  // ...

  handleAuthentication () {
    return new Promise((resolve, reject) => {
      this.auth0.parseHash((err, authResult) => {
        if (err) return reject(err)

        resolve(authResult)
      })
    })
  }
}
{% endhighlight %}

The `parseHash` from the *auth0.js* library would validate and parse tokens and `expires_in`
which determines the duration of the access token. Since it provides the results in a callback
the easiest way would be to return a promise so that it's easier to use that in store action
which we're going to add now by extending our session store:

{% highlight javascript %}
import Authenticator from '@/lib/Authenticator'

const auth = new Authenticator()

const state = {
  authenticated: !!localStorage.getItem('access_token'),
  accessToken: localStorage.getItem('access_token'),
  idToken: localStorage.getItem('id_token'),
  expiresAt: localStorage.getItem('expires_at')
}

const getters = {
  authenticated (state) {
    return state.authenticated
  }
}

const mutations = {
  authenticated (state, authData) {
    state.authenticated = true
    state.accessToken = authData.accessToken
    state.idToken = authData.idToken
    state.expiresAt = authData.expiresIn * 1000 + new Date().getTime()

    localStorage.setItem('access_token', state.accessToken)
    localStorage.setItem('id_token', state.idToken)
    localStorage.setItem('expires_at', state.expiresAt)
  },

  logout (state) {
    state.authenticated = false
    state.accessToken = null
    state.idToken = false

    localStorage.removeItem('access_token')
    localStorage.removeItem('id_token')
    localStorage.removeItem('expires_at')
  }
}

const actions = {
  login () {
    auth.login()
  },

  logout ({ commit }) {
    commit('logout')
  },

  handleAuthentication ({ commit }) {
    auth.handleAuthentication().then(authResult => {
      commit('authenticated', authResult)
    }).catch(err => {
      console.log(err)
    })
  }
}

export default {
  state,
  getters,
  mutations,
  actions
}
{% endhighlight %}

That's the full implementation of our session store. In that store we have `login`,
`logout` and `handleAuehtneication` actions which will set through mutations the
state of our session including storing it in local storage.

Now we need to setup a route which would handle our callback redirect:

{% highlight javascript %}
export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/auth',
      name: 'auth',
      component: Auth
    }
  ]
})
{% endhighlight %}

Finally we need `Auth` component:

{% highlight html %}
// src/views/Auth.vue

<template>
  <div class="authenticating">
    Authenticating...
  </div>
</template>

<script>
import router from '@/router'
import { mapActions } from 'vuex'

export default {
  name: 'Auth',

  methods: mapActions(['handleAuthentication']),

  data () {
    this.handleAuthentication()
    router.push({ name: 'home' })

    return {}
  }
}
</script>
{% endhighlight %}

The `Auth` component will handle user redirect and dispatch `handleAuthentication` action
to validate and parse tokens. Finally it redirects to the `/home` path.

Technically authentication is finished at this point but we have no UI indicator that tells whether
user is authenticated and no way to destroy the session. Let's update the `Navbar` component
to address that:

{% highlight html %}
<template>
  <nav class="navbar navbar-dark bg-dark">
    <a href="#" class="navbar-brand">Auth0 with Vue and Vuex Example</a>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <button v-if="!authenticated" class="btn btn-primary" @click='login()'>Sign In</button>
        <a v-if="authenticated" href="#" class='nav-link' @click='logout()'>Log Out</a>
      </li>
    </ul>
  </nav>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'Header',

  methods: mapActions(['login', 'logout']),

  computed: mapGetters(['authenticated'])
}
</script>
{% endhighlight %}

That is the final version of `Navbar` component which will render Sign In button and Log Out link
when user is authenticated. Also would dispatch `logout` action to destroy user session.

Go ahead and open http://localhost:8080. The authentication is fully functional at this point.

[1]: https://auth0.com/docs/quickstart/spa/vuejs/01-login
[2]: https://vuex.vuejs.org/en/
[3]: https://github.com/michalorman/auth0-with-vue-and-vuex-exmaple
[4]: https://auth0.com/docs/quickstart/spa/vuejs
[5]: https://github.com/vuejs/vue-cli/blob/dev/docs/README.md