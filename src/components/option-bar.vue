<template>
  <div class="options-link">
    <div class="link" v-if="isTeacherLive" @click="goTeacherLive()">
      <img class="live" src="../assets/img/teacher-live-icon.png" />
      {{ text }}
    </div>
    <div class="link" v-else @click="goRouter()">
      <img src="../assets/images/config/icon-option.png" />
      {{ text }}
    </div>
  </div>
</template>

<script>
import config from "@/js/config";
export default {
  props: ["text", "value", "query", "isTeacherLive"],
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
    goTeacherLive() {
      window.open(
        this.$utils.checkUrl(config.url) + "addons/Zhibo/teacher/dist/#/index"
      );
    },
  },
};
</script>
