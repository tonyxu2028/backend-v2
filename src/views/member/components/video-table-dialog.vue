<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-table-dialog-box">
        <div class="meedu-table-dialog-header">
          <span>{{ text }}</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="meedu-table-dialog-body">
          <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="list"
            class="float-left"
          >
            <el-table-column label="课时名称" min-width="32%">
              <template slot-scope="scope">
                <template>
                  <span>{{ scope.row.title }}</span>
                </template>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="课时时长"
              min-width="13%"
              ><template slot-scope="scope">
                <duration-text
                  v-if="!loading"
                  :duration="scope.row.duration"
                ></duration-text>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="已学时长"
              min-width="13%"
              ><template slot-scope="scope">
                <template
                  v-if="
                    typeof scope.row.watch_record['watch_seconds'] !==
                    'undefined'
                  "
                >
                  <duration-text
                    :duration="scope.row.watch_record.watch_seconds"
                  ></duration-text>
                </template>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="是否学完" min-width="10%">
              <template slot-scope="scope">
                <span
                  class="c-green"
                  v-if="
                    typeof scope.row.watch_record['watched_at'] !==
                      'undefined' && scope.row.watch_record.watched_at
                  "
                  >已学完</span
                >
                <span v-else>未学完</span>
              </template>
            </el-table-column>
            <el-table-column label="开始学习时间" min-width="16%">
              <template slot-scope="scope">
                <span
                  v-if="
                    typeof scope.row.watch_record['created_at'] !==
                      'undefined' && scope.row.watch_record.created_at
                  "
                  >{{ scope.row.watch_record.created_at | dateFormat }}</span
                >
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="最近一次学习" min-width="16%">
              <template slot-scope="scope">
                <span
                  v-if="
                    typeof scope.row.watch_record['updated_at'] !==
                      'undefined' && scope.row.watch_record.updated_at
                  "
                  >{{ scope.row.watch_record.updated_at | dateFormat }}</span
                >
                <span v-else>-</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
  },
  props: ["id", "text", "userId"],
  data() {
    return {
      loading: false,
      list: [],
    };
  },
  mounted() {
    if (this.id && this.userId) {
      this.getData();
    }
  },
  methods: {
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {
        course_id: this.id,
        user_id: this.userId,
      };
      this.$api.Member.UserVideoWatchRecords(params).then((res) => {
        this.loading = false;
        let videos = res.data.videos;
        let list = [];
        for (let i in videos) {
          list.push(videos[i]);
        }
        this.list = list;
      });
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
