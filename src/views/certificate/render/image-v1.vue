<template>
  <div class="image-v1-box" ref="dragitem" draggable="true">
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
    return { startX: null, startY: null, endX: null, endY: null };
  },
  mounted() {
    let item = this.$refs.dragitem;
    let that = this;
    item.addEventListener("dragstart", function (ev) {
      this.startX = ev.clientX;
      this.startY = ev.clientY;
    });
    item.addEventListener("dragend", function (ev) {
      this.endX = ev.clientX;
      this.endY = ev.clientY;
      const moveX = this.endX - this.startX;
      const moveY = this.endY - this.startY;
      that.$emit("dragend", "image-v1", moveX, moveY);
    });
  },
};
</script>
<style lang="less" scoped></style>
