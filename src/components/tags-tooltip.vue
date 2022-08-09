<template>
  <el-tooltip class="cursor-pointer" effect="light" placement="top-start">
    <div>
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
