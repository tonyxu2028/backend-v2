<template>
  <draggable
    class="text-v1-box"
    ref="dragitem"
    @start="start"
    @end="end"
    v-bind="dragOptions"
  >
    <div
      :style="{
        'font-size': config.size + 'px',
        color: config.color,
      }"
    >
      {{ config.text }}
    </div>
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
    return {
      startX: null,
      startY: null,
      endX: null,
      endY: null,
      dragOptions: {
        animation: 500,
      },
    };
  },
  mounted() {},
  methods: {
    start(e) {
      console.log(e);
      this.startX = e.originalEvent.clientX;
      this.startY = e.originalEvent.clientY;
    },
    end(e) {
      this.endX = e.originalEvent.clientX;
      this.endY = e.originalEvent.clientY;
      const moveX = this.endX - this.startX;
      const moveY = this.endY - this.startY;
      console.log(moveX, moveY);
      this.$emit("dragend", "text-v1", this.current, moveX, moveY);
    },
  },
};
</script>
<style lang="less" scoped></style>
