<template>
  <div class="qrcode-v1-box">
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
      <div
        class="item"
        @click="change"
        :style="{
          width: config.width + 'px',
          height: config.height + 'px',
        }"
      >
        <div ref="qrcode"></div>
      </div>
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
import QRCode from "qrcodejs2";
export default {
  components: {
    VueDragResize,
  },
  props: ["config", "status", "current", "curindex"],
  data() {
    return {
      curBlockIndex: null,
    };
  },
  watch: {
    status() {
      this.$nextTick(() => {
        this.getData();
      });
    },
    curindex() {
      this.curBlockIndex = this.curindex;
    },
    "config.text"() {
      this.$nextTick(() => {
        this.getData();
      });
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.getData();
    });
  },
  methods: {
    getData() {
      this.$refs.qrcode.innerHTML = "";
      let link = this.config.text;
      var qrcode = new QRCode(this.$refs.qrcode, {
        width: this.config.width,
        height: this.config.height,
        text: link, //表示内容，可以是地址或者是文字'55566'或者参数
        colorDark: "#000000", //前景色
        colorLight: "#ffffff", //背景色
        correctLevel: QRCode.CorrectLevel.Q, //容错级别
      });
    },
    change() {
      this.$emit("change", this.current);
    },
    onResize(e) {
      this.config.width = e.width;
      this.config.height = e.height;
      this.$nextTick(() => {
        this.getData();
      });
    },
    onDrag(e) {
      const moveX = e.left;
      const moveY = e.top;
      this.$emit("dragend", "qrcode-v1", this.current, moveX, moveY);
    },
    blockDestroy() {
      this.$emit("del", this.current);
    },
  },
};
</script>
<style lang="less" scoped>
.qrcode-v1-box {
  width: 100%;
  height: 100%;
}
.item {
  cursor: pointer;
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
