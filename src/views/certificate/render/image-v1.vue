<template>
  <div class="image-v1-box">
    <vue-drag-resize
      ref="dragitem"
      :w="config.width"
      :h="config.height"
      :x="config.x"
      :y="config.y"
      :isResizable="true"
      @resizing="onResize"
      @dragging="onDrag"
    >
      <img
        @click="change"
        :style="{
          width: config.width + 'px',
          height: config.height + 'px',
        }"
        :src="config.url"
      />
      <div
        class="item-options"
        :style="{
          top: '0px',
          left: config.width + 'px',
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
  props: ["config", "current", "status"],
  data() {
    return {
      curBlockIndex: null,
    };
  },
  mounted() {},
  watch: {
    status() {
      this.curBlockIndex = this.status;
    },
  },
  methods: {
    change() {
      this.$emit("change", this.current);
    },
    onResize(e) {
      this.config.width = e.width;
      this.config.height = e.height;
    },
    onDrag(e) {
      const moveX = e.left;
      const moveY = e.top;
      this.$emit("dragend", "image-v1", this.current, moveX, moveY);
    },
    blockDestroy() {
      this.$emit("del", this.current);
    },
  },
};
</script>
<style lang="less" scoped>
img {
  cursor: pointer;
}
.image-v1-box {
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
