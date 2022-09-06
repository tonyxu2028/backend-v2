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
      let params = {
        name: this.value,
      };
      if (this.query) {
        Object.assign(params, {
          query: this.query,
        });
      }
      this.$router.push(params);
    },
  },
};
</script>
