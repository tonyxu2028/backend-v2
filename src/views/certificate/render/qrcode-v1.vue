<template>
  <draggable
    class="qrcode-v1-box"
    ref="dragitem"
    @start="start"
    @end="end"
    v-bind="dragOptions"
  >
    <div
      :style="{
        width: config.width + 'px',
        height: config.height + 'px',
      }"
    >
      <div ref="qrcode"></div>
    </div>
  </draggable>
</template>
<script>
import draggable from "vuedraggable";
import QRCode from "qrcodejs2";
export default {
  components: {
    draggable,
  },
  props: ["config", "status", "current"],
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
  watch: {
    status() {
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
    start(e) {
      this.startX = e.originalEvent.clientX;
      this.startY = e.originalEvent.clientY;
    },
    end(e) {
      this.endX = e.originalEvent.clientX;
      this.endY = e.originalEvent.clientY;
      const moveX = this.endX - this.startX;
      const moveY = this.endY - this.startY;
      this.$emit("dragend", "qrcode-v1", this.current, moveX, moveY);
    },
  },
};
</script>
<style lang="less" scoped></style>
