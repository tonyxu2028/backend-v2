<template>
  <div class="float-left">
    <div
      class="text-v1-box"
      :style="{
        top: config.y + 'px',
        left: config.x + 'px',
      }"
    >
      <div
        :style="{
          width: config.width + 'px',
          height: config.height + 'px',
        }"
        :src="item.config.url"
      >
        {{}}
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
