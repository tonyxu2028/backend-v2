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
      <sub-users
        :id="id"
        v-if="tabActive === 'sub-users' && through('addons.Paper.paper.users')"
      ></sub-users>
      <watch-records
        :id="id"
        v-else-if="
          tabActive === 'watch-records' &&
          through('addons.Paper.paper.userPaper')
        "
      ></watch-records>
      <statistics
        :id="id"
        v-else-if="
          tabActive === 'statistics' && through('addons.Paper.paper.statistics')
        "
      ></statistics>
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
      tabActive: "watch-records",
      tabs: [
        {
          name: "考试记录",
          key: "watch-records",
        },
        {
          name: "考试统计",
          key: "statistics",
        },
        {
          name: "付费学员",
          key: "sub-users",
        },
      ],
    };
  },
  computed: {
    ...mapState(["user"]),
  },
  methods: {
    through(val) {
      if (!this.user) {
        return false;
      }
      return typeof this.user.permissions[val] !== "undefined";
    },
  },
};
</script>

<style lang="less" scoped></style>
