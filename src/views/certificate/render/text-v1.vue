<template>
  <div class="text-v1-box">
    <vue-drag-resize
      ref="dragitem"
      w="auto"
      h="auto"
      :x="x"
      :y="y"
      :isResizable="false"
      @dragging="onDrag"
    >
      <div
        @click="change"
        class="text"
        :style="{
          'font-size': size * config.size + 'px',
          color: config.color,
        }"
      >
        {{ config.text }}
      </div>
      <div
        class="item-options"
        :style="{
          top: '-2px',
          right: '-38px',
        }"
      >
        <div
          class="btn-item"
          @click="blockDestroy()"
          v-if="curBlockIndex === current"
        >
          <i class="el-icon-delete-solid"></i>
        </div>
      </div>
    </vue-drag-resize>
  </div>
</template>
<script>
import VueDragResize from "vue-drag-resize";
export default {
  components: {
    VueDragResize,
  },
  props: ["config", "current", "status", "maxw", "size"],
  data() {
    return {
      curBlockIndex: null,
    };
  },
  watch: {
    status() {
      this.curBlockIndex = this.status;
    },
  },
  computed: {
    x() {
      return this.size * this.config.x;
    },
    y() {
      return this.size * this.config.y;
    },
  },
  mounted() {},
  methods: {
    change() {
      this.$emit("change", this.current);
    },
    onDrag(e) {
      const moveX = e.left / this.size;
      const moveY = e.top / this.size;
      this.$emit("dragend", "text-v1", this.current, moveX, moveY);
    },
    blockDestroy() {
      this.$emit("del", this.current);
    },
  },
};
</script>
<style lang="less" scoped>
.text {
  width: auto;
  height: auto;
  display: flex;
  cursor: pointer;
}
.text-v1-box {
  width: 100%;
  height: 100%;
}
.item-options {
  position: absolute;
  width: auto;
  height: 36px;
  cursor: pointer;

  .btn-item {
    color: white;
    background-color: @primary-color;
    width: 36px;
    height: 36px;
    float: left;
    text-align: center;
    line-height: 36px;

    &:hover {
      background-color: rgba(@primary-color, 0.8);
    }

    &:first-child {
      border-top-left-radius: 2px;
      border-bottom-left-radius: 2px;
    }

    &:last-child {
      border-top-right-radius: 2px;
      border-bottom-right-radius: 2px;
    }
  }
}
</style>
