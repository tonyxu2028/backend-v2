<template>
  <div class="image-v1-box">
    <img
      :style="{
        width: config.width + 'px',
        height: config.height + 'px',
      }"
      :src="config.url"
    />
  </div>
</template>
<script>
export default {
  props: ["config"],
  data() {
    return {};
  },
};
</script>
<style lang="less" scoped></style>
