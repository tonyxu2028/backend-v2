<template>
  <div class="float-left">
    <div class="text-v1-box">
      <div
        :style="{
          width: config.width + 'px',
          height: config.height + 'px',
        }"
      >
        {{ config.text }}
      </div>
    </div>
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
