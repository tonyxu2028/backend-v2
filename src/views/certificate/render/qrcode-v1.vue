<template>
  <div class="qrcode-v1-box" ref="dragitem" draggable="true" :id="current">
    <div
      :style="{
        width: config.width + 'px',
        height: config.height + 'px',
      }"
    >
      <div ref="qrcode"></div>
    </div>
  </div>
</template>
<script>
import QRCode from "qrcodejs2";
export default {
  props: ["config", "status", "current"],
  data() {
    return {
      startX: null,
      startY: null,
      endX: null,
      endY: null,
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
    let item = this.$refs.dragitem;
    let that = this;
    item.addEventListener("dragstart", function (ev) {
      this.startX = ev.clientX;
      this.startY = ev.clientY;
    });
    item.addEventListener("drag", function (ev) {
      console.log("drag正在拖啦");
    });
    item.addEventListener("dragleave", function (ev) {
      console.log(2);
    });
    item.addEventListener("dragend", function (ev) {
      this.endX = ev.clientX;
      this.endY = ev.clientY;
      const moveX = this.endX - this.startX;
      const moveY = this.endY - this.startY;
      that.$emit("dragend", "qrcode-v1", that.current, moveX, moveY);
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
  },
};
</script>
<style lang="less" scoped></style>
