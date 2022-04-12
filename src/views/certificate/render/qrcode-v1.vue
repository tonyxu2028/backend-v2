<template>
  <div class="qrcode-v1-box">
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
  props: ["config", "status"],
  data() {
    return {};
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
  },
};
</script>
<style lang="less" scoped></style>
