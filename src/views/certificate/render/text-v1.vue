<template>
  <div
    class="text-v1-box"
    :style="{
      top: config.y + 'px',
      left: config.x + 'px',
    }"
  >
    <div
      class="w-500px"
      :style="{
        'font-size': config.size + 'px',
        color: config.color,
      }"
    >
      {{ config.text }}
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
