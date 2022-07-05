<template>
  <div class="options-link">
    <div class="link" @click="goRouter()">
      <img src="../assets/images/config/icon-option.png" />
      {{ text }}
    </div>
  </div>
</template>

<script>
export default {
  props: ["text", "value", "query"],
  methods: {
    goRouter() {
      this.$router.push({
        name: this.value,
        query: this.query,
      });
    },
  },
};
</script>
