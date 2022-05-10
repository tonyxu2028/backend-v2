<template>
  <vue-drag-resize
    :key="current"
    @clicked="change"
    ref="dragitem"
    :w="width"
    :h="height"
    :minw="1"
    :minh="1"
    :x="x"
    :y="y"
    @resizing="onResize"
    @dragging="onDrag"
    :parentLimitation="true"
    :isActive="curBlockIndex === current"
  >
    <div
      class="item"
      :style="{
        width: '100%',
        height: '100%',
      }"
    >
      <div ref="qrcode"></div>
    </div>
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
import QRCode from "qrcodejs2";
export default {
  components: {
    VueDragResize,
  },
  props: ["config", "status", "current", "curindex", "size"],
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
        width: this.width,
        height: this.height,
        text: link, //表示内容，可以是地址或者是文字'55566'或者参数
        colorDark: "#000000", //前景色
        colorLight: "#ffffff", //背景色
        correctLevel: QRCode.CorrectLevel.Q, //容错级别
      });
    },
    change() {
      this.curBlockIndex = this.curindex;
      this.$emit("change", this.current);
    },
    onResize(e) {
      this.config.width = e.width / this.size;
      this.config.height = e.height / this.size;
      this.$nextTick(() => {
        this.getData();
      });
    },
    onDrag(e) {
      const moveX = e.left / this.size;
      const moveY = e.top / this.size;
      this.$emit("dragend", "qrcode-v1", this.current, moveX, moveY);
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
