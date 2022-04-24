<template>
  <div
    class="text-v1-box"
    ref="dragitem"
    draggable="true"
    :style="{
      top: config.y + 'px',
      left: config.x + 'px',
    }"
  >
    <div
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
  props: ["config", "current"],
  data() {
    return {
      startX: null,
      startY: null,
      endX: null,
      endY: null,
    };
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
      that.$emit("dragend", "text-v1", that.current, moveX, moveY);
    });
  },
};
</script>
<style lang="less" scoped></style>
