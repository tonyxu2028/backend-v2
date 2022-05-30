<template>
  <div class="float-left">
    <div class="float-left mb-30">
      <p-button
        text="添加学员"
        p="addons.Paper.paper.users.add"
        @click="showUserAddWin = true"
        type="primary"
      ></p-button>
      <el-button @click="exportexcel" type="primary">导出表格</el-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="results"
          class="float-left"
        >
          <el-table-column prop="user_id" label="学员ID" width="80">
          </el-table-column>
          <el-table-column label="手机号" width="150">
            <template slot-scope="scope">
              <span>{{ scope.row.user.mobile }}</span>
            </template>
          </el-table-column>
          <el-table-column label="学员">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user">
                <div class="avatar">
                  <img :src="scope.row.user.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">{{ scope.row.user.nick_name }}</div>
              </div>
              <span class="c-red" v-else>学员不存在</span>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="200">
            <template slot-scope="scope">
              <p-link
                text="删除"
                p="addons.Paper.paper.users.delete"
                type="danger"
                @click="destory(scope.row.user_id)"
              ></p-link>
            </template>
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
    <user-add-comp
      :show="showUserAddWin"
      @close="showUserAddWin = false"
      @confirm="userAddChange"
    ></user-add-comp>
  </div>
</template>

<script>
import moment from "moment";
import UserAddComp from "@/components/user-add";

export default {
  components: {
    UserAddComp,
  },
  props: ["id"],
  data() {
    return {
      pageName: "paperUser-list",
      showUserAddWin: false,
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
      loading: false,
      results: [],
      electedRows: null,
    };
  },
  mounted() {
    this.getResults();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    firstPageLoad() {
      this.pagination.page = 1;
      this.getResults();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.getResults();
    },
    paginationSizeChange(size) {
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
      Object.assign(params, this.pagination);
      this.$api.Exam.Paper.User(this.id, params).then((res) => {
        this.loading = false;
        this.results = res.data.data.data;
        this.total = res.data.data.total;
        this.question_count = res.data.question_count;
      });
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
          this.$api.Exam.Paper.DestoryUser(this.id, item)
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
    userAddChange(rows) {
      let ids = [];
      rows.forEach((item) => {
        ids.push(item.mobile);
      });

      this.$api.Exam.Paper.Add(this.id, {
        id: this.id,
        mobiles: ids,
      })
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.firstPageLoad();
          this.showUserAddWin = false;
        })
        .catch((e) => {
          this.$message.error(e.message);
        });
    },
    exportexcel() {
      if (this.loading) {
        return;
      }
      this.loading = true;

      let params = {
        page: 1,
        size: this.total,
      };
      Object.assign(params, this.filter);

      this.$api.Exam.Paper.User(this.id, params).then((res) => {
        if (res.data.data.total === 0) {
          this.$message.error("数据为空");
          this.loading = false;
          return;
        }

        let filename = "考试卷订阅学员.xlsx";
        let sheetName = "sheet1";

        let data = [["学员ID", "学员", "手机号", "时间"]];
        res.data.data.data.forEach((item) => {
          data.push([
            item.user_id,
            item.user.nick_name,
            item.user.mobile,
            moment(item.created_at).format("YYYY-MM-DD HH:mm"),
          ]);
        });
        let wscols = [{ wch: 10 }, { wch: 20 }, { wch: 15 }, { wch: 20 }];
        this.$utils.exportExcel(data, filename, sheetName, wscols);
        this.loading = false;
      });
    },
  },
};
</script>
