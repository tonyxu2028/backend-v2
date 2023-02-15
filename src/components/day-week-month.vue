<template>
  <div
    class="controls-box"
    :class="{
      active: active,
    }"
  >
    <div
      class="item"
      :class="{ active: current === index }"
      v-for="(item, index) in tabs"
      :key="index"
      :id="item.id"
      @click="change(item.id, index)"
    >
      {{ item.name }}
    </div>
  </div>
</template>
<script>
import moment from "moment";
export default {
  props: ["active"],
  data() {
    return {
      current: 0,
    };
  },
  computed: {
    tabs() {
      let tabs = [];
      if (this.active) {
        tabs = [
          { id: 7, name: "周" },
          { id: 30, name: "月" },
        ];
      } else {
        tabs = [
          { id: 1, name: "日" },
          { id: 7, name: "周" },
          { id: 30, name: "月" },
        ];
      }
      return tabs;
    },
  },
  methods: {
    change(key, index) {
      this.current = index;
      let start_at = null;
      let end_at = moment().add(1, "days").format("YYYY-MM-DD");
      if (key === 1) {
        start_at = moment().format("YYYY-MM-DD");
      } else if (key === 7) {
        start_at = moment().subtract(6, "days").format("YYYY-MM-DD");
      } else if (key === 30) {
        start_at = moment().subtract(29, "days").format("YYYY-MM-DD");
      }
      this.$emit("change", start_at, end_at);
    },
  },
};
</script>

<style lang="less" scoped>
.controls-box {
  width: 112px;
  height: 44px;
  border-radius: 4px;
  border: 1px solid #e5e5e5;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  padding: 0px 15px;
  box-sizing: border-box;
  &.active {
    width: 103px;
    padding: 0px 20px;
  }
  .item {
    font-size: 14px;
    font-weight: 400;
    color: #999999;
    line-height: 14px;
    cursor: pointer;
    &:hover {
      color: #333333;
    }
    &.active {
      color: #333333;
    }
  }
}
</style>
