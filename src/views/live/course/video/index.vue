<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" :title="title"></back-bar>
    <div class="float-left mb-30">
      <p-button
        text="添加"
        @click="
          $router.push({
            name: 'LiveCourseVideoCreate',
            query: { course_id: pagination.course_id },
          })
        "
        type="primary"
        p="addons.Zhibo.course_video.store"
      >
      </p-button>
      <p-button
        text="章节管理"
        @click="
          $router.push({
            name: 'LiveCourseChapter',
            query: { id: pagination.course_id },
          })
        "
        type="primary"
        p="addons.Zhibo.course_chapter.list"
      >
      </p-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="results"
          class="float-left"
        >
          <el-table-column prop="name" label="标题" min-width="42%">
            <template slot-scope="scope">
              <template v-if="scope.row.chapter">
                <span>{{ scope.row.chapter.name }}</span>
                <span class="mx-5">/</span>
              </template>
              <span>{{ scope.row.title }}</span>
            </template>
          </el-table-column>
          <el-table-column label="直播时间" min-width="18%">
            <template slot-scope="scope">{{
              scope.row.published_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="状态" min-width="18%">
            <template slot-scope="scope">
              <span
                :class="{
                  'c-green': scope.row.status === 1,
                  'c-yellow': scope.row.status === 0,
                  'c-gray': scope.row.status === 2,
                }"
                >· {{ scope.row.status_text }}</span
              >
            </template>
          </el-table-column>
          <el-table-column
            fixed="right"
            label="操作"
            min-width="22%"
            align="right"
          >
            <template slot-scope="scope">
              <p-link
                text="学员"
                type="primary"
                @click="
                  $router.push({
                    name: 'LiveCourseVideoUsers',
                    query: {
                      id: scope.row.id,
                      course_id: scope.row.course_id,
                    },
                  })
                "
                p="addons.Zhibo.course_video.stats"
              >
              </p-link>
              <p-link
                v-if="scope.row.status === 2"
                text="统计"
                type="primary"
                class="ml-5"
                @click="showStatsDialog(scope.row.id)"
                p="addons.Zhibo.course_video.stats"
              >
              </p-link>
              <el-dropdown>
                <el-link type="primary" class="el-dropdown-link ml-5">
                  更多<i class="el-icon-arrow-down el-icon--right"></i>
                </el-link>
                <el-dropdown-menu slot="dropdown">
                  <p-dropdown-item
                    text="编辑"
                    type="primary"
                    @click="
                      $router.push({
                        name: 'LiveCourseVideoUpdate',
                        query: {
                          id: scope.row.id,
                          course_id: scope.row.course_id,
                        },
                      })
                    "
                    p="addons.Zhibo.course_video.update"
                  >
                  </p-dropdown-item>
                  <p-dropdown-item
                    text="聊天"
                    type="primary"
                    @click="
                      $router.push({
                        name: 'LiveCourseVideoChats',
                        query: {
                          id: scope.row.id,
                          course_id: scope.row.course_id,
                        },
                      })
                    "
                    p="addons.Zhibo.chat.list"
                  >
                  </p-dropdown-item>
                  <p-dropdown-item
                    text="删除"
                    type="danger"
                    @click="destory(scope.row.id)"
                    p="addons.Zhibo.course_video.delete"
                  >
                  </p-dropdown-item>
                </el-dropdown-menu>
              </el-dropdown>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="float-left mt-30 text-center">
        <el-pagination
          @size-change="paginationSizeChange"
          @current-change="paginationPageChange"
          :current-page="pagination.page"
          :page-sizes="[10, 20, 50, 100, 1000]"
          :page-size="pagination.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        >
        </el-pagination>
      </div>
    </div>
    <stats-dialog
      :id="currentId"
      :show="visiable"
      @close="closeStatsDialog()"
    ></stats-dialog>
  </div>
</template>

<script>
import StatsDialog from "../../components/stats-dialog.vue";
export default {
  components: {
    StatsDialog,
  },
  data() {
    return {
      pageName: "liveVideo-list",
      pagination: {
        course_id: this.$route.query.id,
        keywords: "",
        page: 1,
        size: 1000,
      },
      total: 0,
      loading: false,
      results: [],
      title: null,
      visiable: false,
      currentId: null,
    };
  },
  watch: {
    "$route.query.id"() {
      this.pagination.page = 1;
      this.pagination.keywords = "";
    },
  },
  activated() {
    this.getResults();
    this.title = this.$route.query.title;
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.pagination.keywords = "";
      this.getResults();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getResults();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getResults();
    },
    getResults() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      this.pagination.course_id = this.$route.query.id;
      Object.assign(params, this.pagination);
      this.$api.Course.Live.Course.Video.List(params).then((res) => {
        this.loading = false;
        this.results = res.data.data;
        this.total = res.data.total;
        document.title = this.title;
      });
    },
    showStatsDialog(id) {
      this.currentId = id;
      this.visiable = true;
    },
    closeStatsDialog() {
      this.visiable = false;
    },
    destory(item) {
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          //点击确定按钮的操作
          if (this.loading) {
            return;
          }
          this.loading = true;
          this.$api.Course.Live.Course.Video.Destory(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.getResults();
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
  },
};
</script>
