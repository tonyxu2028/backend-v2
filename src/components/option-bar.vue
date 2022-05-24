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
  props: ["text", "value"],
  methods: {
    goRouter() {
      if (this.value === "积分") {
        this.$router.push({
          name: "SystemCreditSignConfig",
        });
      } else if (this.value === "微信公众号") {
        this.$router.push({
          name: "SystemMpwechatConfig",
        });
      } else if (this.value === "图文") {
        this.$router.push({
          name: "SystemTopicConfig",
        });
      } else if (this.value === "电子书") {
        this.$router.push({
          name: "SystemBookConfig",
        });
      } else if (this.value === "播放器配置") {
        this.$router.push({
          name: "SystemPlayerConfig",
        });
      } else if (this.value === "直播") {
        this.$router.push({
          name: "SystemLiveConfig",
        });
      } else if (
        this.value === "腾讯云HLS加密" ||
        this.value === "阿里云HLS加密"
      ) {
        this.$router.push({
          name: "SystemVideoHlsConfig",
        });
      } else {
        this.$router.push({
          name: "SystemConfig",
          query: { key: this.value },
        });
      }
    },
  },
};
</script>
