<template>
  <el-tooltip class="cursor-pointer" effect="light" placement="top-start">
    <div v-if="current && current > 0">
      <el-tag
        class="ml-5 mb-5"
        v-for="(item, index) in tags.slice(0, current)"
        :key="index"
      >
        {{ item.name }}
      </el-tag>
      ...
    </div>
    <div v-else>
      <el-tag class="ml-5 mb-5" v-for="(item, index) in tags" :key="index">
        {{ item.name }}
      </el-tag>
    </div>
    <div slot="content">
      <el-tag class="ml-5 mb-5" v-for="(item, index) in tags" :key="index">
        {{ item.name }}
      </el-tag>
    </div>
  </el-tooltip>
</template>
<script>
export default {
  props: ["tags"],
  data() {
    return {
      current: null,
    };
  },
  mounted() {
    let value = "";
    for (let i = 0; i < this.tags.length; i++) {
      value += this.tags[i].name;
      if (value.length > 7) {
        this.current = 1;
        break;
      }
    }
    console.log(this.current);
  },
};
</script>
<style lang="less" scoped>
.cursor-pointer {
  display: -webkit-box;
  width: 100%;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  cursor: pointer;
}
</style>
