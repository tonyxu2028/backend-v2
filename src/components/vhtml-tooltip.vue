<template>
  <el-tooltip
    class="cursor-pointer"
    effect="dark"
    :content="label"
    placement="top-start"
  >
    <div>
      <p v-html="title"></p>
    </div>
  </el-tooltip>
</template>
<script>
export default {
  props: ["label"],
  computed: {
    title() {
      if (!this.label) {
        return "";
      }
      if (this.label.length > 48) {
        return this.label.slice(0, 48) + "...";
      }

      return this.label;
    },
  },
  mounted() {
    console.log(this.label.slice(0, 48));
  },
};
</script>
<style lang="less" scoped>
.cursor-pointer {
  width: 100%;
  cursor: pointer;
}
</style>
