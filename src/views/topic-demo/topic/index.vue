<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="图文管理"></back-bar>
    <div class="float-left mb-30">
      <p-button
          text="新建图文"
          p="demo–topic.topic.store"
          @click="addTopic"
          type="primary"
      >
      </p-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="topics"
            row-key="id"
            class="float-left"
        >
          <el-table-column prop="id" label="序号" width="150">
          </el-table-column>

          <el-table-column label="图文标题"
          ><template slot-scope="scope">
            <span>{{ scope.row.title }} </span>
          </template>
          </el-table-column>

          <el-table-column prop="context" label="图文内容" width="300">
          </el-table-column>

          <el-table-column prop="published_at" label="创建时间" width="300">
          </el-table-column>

          <el-table-column fixed="right" label="操作" width="100">
            <template slot-scope="scope">
              <p-link
                  text="编辑"
                  p="demo–topic.topic.update"
                  type="primary"
                  @click="updateTopic(scope.row.id)"
              ></p-link>
              <p-link
                  text="删除"
                  p="demo–topic.topic.destroy"
                  class="ml-5"
                  type="danger"
                  @click="destroy(scope.row.id)"
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
  </div>
</template>

<script>
export default {
  data(){
    return {
      topics: [],
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
      loading: false,
      editId:null,
    };
  },
  mounted() {
    this.getTopics();
  },
  methods: {
    addTopic() {
      this.formTitle = "新建图文";
      this.editId = null;
    },
    updateTopic(id) {
      this.formTitle = "编辑图文";
      this.editId = id;
    },
    closeForm() {
      this.formTitle = "";
      this.editId = null;
    },
    sucEvt() {
      this.closeForm();
      this.getTopics();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.getTopics();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getTopics();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getTopics();
    },
    getTopics() {// 列表的数据获取方法
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination);
      this.$api.TopicDemo.Topic.List(params).then((res) => {
        this.loading = false;
        this.topics = res.data.data;
        this.total = res.data.total;
      });
    },
    destroy(id) {
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
            this.$api.TopicDemo.Topic.Destroy(id)
                .then(() => {
                  this.loading = false;
                  this.$message.success(this.$t("common.success"));
                  this.paginationReset();
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
  }
}
</script>

<style scoped lang="less">

</style>

