<template>
  <div class="meedu-main-body">
    <div class="float-left">
      <div class="float-left mb-30">
        <p-button
          text="新建"
          p="addons.cert.store"
          @click="$router.push({ name: 'CertificateCreate' })"
          type="primary"
        ></p-button>
      </div>
      <div class="float-left" v-loading="loading">
        <div class="float-left">
          <el-table :data="list" class="float-left">
            <el-table-column prop="id" label="ID" width="150">
            </el-table-column>
            <el-table-column label="证书名"
              ><template slot-scope="scope">
                <span>{{ scope.row.name }} </span>
              </template>
            </el-table-column>
            <el-table-column label="创建时间" sortable width="200">
              <template slot-scope="scope">{{
                scope.row.created_at | dateFormat
              }}</template>
            </el-table-column>
            <el-table-column fixed="right" label="操作" width="150">
              <template slot-scope="scope">
                <p-link
                  p="addons.cert.users"
                  type="primary"
                  text="授予"
                  @click="
                    $router.push({
                      name: 'CertificateUsers',
                      query: { id: scope.row.id },
                    })
                  "
                ></p-link>
                <p-link
                  p="addons.cert.update"
                  class="ml-5"
                  type="primary"
                  text="编辑"
                  @click="
                    $router.push({
                      name: 'CertificateUpdate',
                      query: { id: scope.row.id },
                    })
                  "
                ></p-link>
                <p-link
                  text="删除"
                  class="ml-5"
                  p="addons.cert.delete"
                  type="danger"
                  @click="destory(scope.row.id)"
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
  </div>
</template>
<script>
export default {
  data() {
    return {
      pageName: "certificate-list",
      loading: false,
      list: [],
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
    };
  },
  activated() {
    this.getList();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.getList();
    },
    paginationSizeChange(size) {
      this.pagination.size = size;
      this.getList();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getList();
    },
    getList() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Certificate.List(this.pagination).then((res) => {
        this.loading = false;
        this.list = res.data.data.data;
        this.total = res.data.data.total;
      });
    },
    destory(id) {
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
          this.$api.Certificate.Destroy(id)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.getList();
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
