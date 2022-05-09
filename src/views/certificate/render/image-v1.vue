<template>
  <vue-drag-resize
    ref="dragitem"
    v-if="config"
    :w="width"
    :h="height"
    :x="x"
    :y="y"
    @resizing="onResize"
    @dragging="onDrag"
    :parentLimitation="true"
  >
    <img
      @click="change"
      :style="{
        width: '100%',
        height: '100%',
      }"
      :src="config.url"
    />
    <div
      class="item-options"
      :style="{
        top: '0px',
        left: width + 'px',
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
</template>
<script>
import VueDragResize from "vue-drag-resize";
export default {
  components: {
    VueDragResize,
  },
  props: ["config", "current", "status", "size"],
  data() {
    return {
      curBlockIndex: null,
    };
  },
  mounted() {},
  computed: {
    width() {
      return this.size * this.config.width;
    },
    height() {
      return this.size * this.config.height;
    },
    x() {
      return this.size * this.config.x;
    },
    y() {
      return this.size * this.config.y;
    },
  },
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
      this.config.width = e.width / this.size;
      this.config.height = e.height / this.size;
    },
    onDrag(e) {
      const moveX = e.left / this.size;
      const moveY = e.top / this.size;
      this.$emit("dragend", "image-v1", this.current, moveX, moveY);
    },
    blockDestroy() {
      this.$confirm("确认删除？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          this.$emit("del", this.current);
        })
        .catch(() => {
          //点击删除按钮的操作
        });
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
