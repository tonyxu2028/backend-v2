<template>
  <div class="meedu-main-body" v-if="id">
    <back-bar class="mb-30" title="试卷学员"></back-bar>

    <div class="float-left">
      <div class="float-left">
        <el-tabs v-model="tabActive">
          <el-tab-pane
            :label="item.name"
            :name="item.key"
            v-for="(item, index) in tabs"
            :key="index"
          ></el-tab-pane>
        </el-tabs>
      </div>
    </div>

    <div class="float-left">
      <sub-users :id="id" v-if="tabActive === 'sub-users'"></sub-users>
      <watch-records
        :id="id"
        v-else-if="tabActive === 'watch-records'"
      ></watch-records>
      <statistics :id="id" v-else-if="tabActive === 'statistics'"></statistics>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import SubUsers from "./components/sub-users.vue";
import WatchRecords from "./components/watch-records.vue";
import Statistics from "./components/statistics.vue";

export default {
  components: {
    SubUsers,
    WatchRecords,
    Statistics,
  },
  data() {
    return {
      id: this.$route.query.id,
      showUserAddWin: false,
      tabActive: null,
      tabs: [],
    };
  },
  computed: {
    ...mapState(["user"]),
  },
  mounted() {
    this.params();
  },
  methods: {
    params() {
      let data = [];
      if (this.through("addons.Paper.paper.userPaper")) {
        data.push({
          name: "考试记录",
          key: "watch-records",
        });
      }
      if (this.through("addons.Paper.paper.statistics")) {
        data.push({
          name: "考试统计",
          key: "statistics",
        });
      }
      if (this.through("addons.Paper.paper.users")) {
        data.push({
          name: "付费学员",
          key: "sub-users",
        });
      }

      this.tabActive = data[0].key;
      this.tabs = data;
    },
    through(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
  },
};
</script>

<style lang="less" scoped></style>
