<template>
  <draggable class="image-v1-box" ref="dragitem" @start="start" @end="end">
    <img
      :style="{
        width: config.width + 'px',
        height: config.height + 'px',
      }"
      :src="config.url"
    />
  </draggable>
</template>
<script>
import draggable from "vuedraggable";
export default {
  components: {
    draggable,
  },
  props: ["config", "current"],
  data() {
    return { startX: null, startY: null, endX: null, endY: null };
  },
  mounted() {},
  methods: {
    start(e) {
      this.startX = e.originalEvent.clientX;
      this.startY = e.originalEvent.clientY;
    },
    end(e) {
      this.endX = e.originalEvent.clientX;
      this.endY = e.originalEvent.clientY;
      const moveX = this.endX - this.startX;
      const moveY = this.endY - this.startY;
      this.$emit("dragend", "image-v1", this.current, moveX, moveY);
    },
  },
};
</script>
<style lang="less" scoped></style>
