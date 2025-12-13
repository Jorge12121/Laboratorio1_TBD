<script setup>
import { useRoute, useRouter } from 'vue-router'
import LoginForm from '../components/LoginForm.vue'

const route = useRoute()
const router = useRouter()

const onLoginSuccess = () => {
  const redirect = route.query.redirect || '/mapa'
  router.replace(String(redirect))
}
</script>

<template>
  <LoginForm @login-success="onLoginSuccess" />
</template>
