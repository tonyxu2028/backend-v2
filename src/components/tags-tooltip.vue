<template>
  <el-tooltip
    class="cursor-pointer"
    effect="light"
    placement="top"
    popper-class="tip-class"
  >
    <div v-if="current && current > 0">
      <el-tag
        size="mini"
        class="ml-5 mb-5"
        v-for="(item, index) in tags.slice(0, current)"
        :key="index"
      >
        {{ item.name }}
      </el-tag>
      ...
    </div>
    <div v-else>
      <el-tag
        size="mini"
        class="ml-5 mb-5"
        v-for="(item, index) in tags"
        :key="index"
      >
        {{ item.name }}
      </el-tag>
    </div>
    <div slot="content">
      <el-tag
        size="mini"
        class="ml-5 mb-5"
        v-for="(item, index) in tags"
        :key="index"
      >
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
      if (value.length > 8 && window.innerWidth >= 1700) {
        this.current = 1;
        break;
      } else if (value.length > 7 && window.innerWidth >= 1600) {
        this.current = 1;
        break;
      } else if (value.length > 4 && window.innerWidth < 1600) {
        this.current = 1;
        break;
      }
    }
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
