<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="聊天记录"></back-bar>
    <div class="float-left">
      <p-button
        text="删除"
        @click="delUser"
        type="danger"
        p="addons.Zhibo.chat.delete"
      >
      </p-button>
    </div>
    <div class="float-left mt-30" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          @selection-change="handleSelectionChange"
          class="float-left"
        >
          <el-table-column type="selection" width="55"></el-table-column>
          <el-table-column prop="id" sortable label="ID" width="80">
          </el-table-column>
          <el-table-column label="学员" width="300">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.msg_body">
                {{ scope.row.msg_body.nick_name }}
              </div>
              <span class="c-red" v-else>学员不存在</span>
            </template>
          </el-table-column>
          <el-table-column label="角色" width="300">
            <template slot-scope="scope">
              <template v-if="scope.row.msg_body">
                <span
                  v-if="
                    scope.row.msg_body.role &&
                    scope.row.msg_body.role === 'student'
                  "
                  class="c-gray"
                  >学生</span
                >
                <span v-else class="c-red">{{
                  scope.row.msg_body.role &&
                  scope.row.msg_body.role === "assistant"
                    ? "助教"
                    : "讲师"
                }}</span>
              </template>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="聊天内容">
            <template slot-scope="scope">
              <template v-if="scope.row.msg_body">
                <span>{{ scope.row.msg_body.content }}</span>
              </template>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column sortable label="时间" width="200">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
        </el-table>
      </div>
      <div class="float-left mt-30 text-center">
        <el-pagination
          @size-change="paginationSizeChange"
          @current-change="paginationPageChange"
          :current-page="pagination.page"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pagination.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        >
        </el-pagination>
      </div>
    </div>
  </div>
</template>
<script>
import DurationText from "@/components/duration-text";

export default {
  data() {
    return {
      pageName: "liveVideoChats-list",
      video_id: this.$route.query.id,
      pagination: {
        course_id: this.$route.query.course_id,
        page: 1,
        size: 10,
      },
      filter: {
        mobile: null,
        nick_name: null,
      },
      total: 0,
      loading: false,
      list: [],
      selectedRows: null,
    };
  },
  activated() {
    this.getData();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.filter.nick_name = null;
      this.filter.mobile = null;
      this.getData();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      this.video_id = this.$route.query.id;
      this.pagination.course_id = this.$route.query.course_id;
      Object.assign(params, this.pagination);
      this.$api.Course.Live.Course.Video.Chat(
        this.pagination.course_id,
        this.video_id,
        params
      ).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
    handleSelectionChange(rows) {
      this.selectedRows = rows;
    },
    delUser() {
      if (this.selectedRows === null || this.selectedRows.length === 0) {
        this.$message.warning("请选择需要删除的聊天记录");
        return;
      }
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          let ids = [];
          this.selectedRows.forEach((item) => {
            ids.push(item.id);
          });

          this.$api.Course.Live.Course.Video.ChatDestoryMulti({
            ids: ids,
          })
            .then(() => {
              this.firstPageLoad();
              this.$message.success(this.$t("common.success"));
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
  },
};
</script>
