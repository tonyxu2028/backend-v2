<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="直播课程分类"></back-bar>

    <div class="float-left mb-30">
      <p-button
        text="添加分类"
        @click="addCategory"
        type="primary"
        p="addons.Zhibo.course_category.store"
      >
      </p-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          row-key="id"
          class="float-left"
          :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        >
          <el-table-column prop="sort" label="排序" width="100">
          </el-table-column>
          <el-table-column prop="name" label="课程名"> </el-table-column>
          <el-table-column label="下属课程" width="150">
            <template slot-scope="scope">
              <span>{{ scope.row.courses_count }}个</span>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="100">
            <template slot-scope="scope">
              <p-link
                text="编辑"
                type="primary"
                @click="updateCategory(scope.row.id)"
                p="addons.Zhibo.course_category.update"
              ></p-link>
              <p-link
                class="ml-5"
                text="删除"
                type="danger"
                @click="destory(scope.row.id)"
                p="addons.Zhibo.course_category.delete"
              ></p-link>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
    <categories-dialog
      :key="updateId"
      v-if="showAddWin"
      :categories="categories"
      :text="tit"
      :id="updateId"
      @close="showAddWin = false"
      @success="successEvt"
    ></categories-dialog>
  </div>
</template>

<script>
import CategoriesDialog from "./components/categories-dialog";
export default {
  components: {
    CategoriesDialog,
  },
  data() {
    return {
      pageName: "liveCategory-list",
      loading: false,
      list: [],
      categories: [],
      showAddWin: false,
      tit: null,
      updateId: null,
    };
  },
  mounted() {
    this.params();
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
    addCategory() {
      this.tit = "添加分类";
      this.updateId = null;
      this.showAddWin = true;
    },
    updateCategory(id) {
      this.tit = "编辑分类";
      this.updateId = id;
      this.showAddWin = true;
    },
    successEvt() {
      this.showAddWin = false;
      this.params();
      this.getData();
    },
    params() {
      this.$api.Course.Live.Course.Category.Create().then((res) => {
        this.categories = res.data.categories;
      });
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Course.Live.Course.Category.List().then((res) => {
        this.loading = false;
        this.list = res.data;
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
          this.$api.Course.Live.Course.Category.Destory(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.params();
              this.getData();
            })
            .catch((e) => {
              this.loading = false;
              this.$message.warning(e.message);
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
  },
};
</script>
